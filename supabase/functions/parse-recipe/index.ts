const GEMINI_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const SYSTEM_PROMPT = `You are a recipe parser. Given either raw recipe text, a recipe article URL, or a YouTube video URL, extract and return a structured recipe as JSON.
Return ONLY valid JSON with no markdown, no backticks, no explanation. Exactly this structure:
{
  "title": "string",
  "duration_minutes": number,
  "category": "rice" | "noodle" | "meat" | "seafood" | "vegetables" | "snacks" | "desserts",
  "ingredients": [
    {
      "id": "i001",
      "name": "string",
      "quantity": "string",
      "category": "produce" | "protein" | "dairy" | "pantry"
    }
  ],
  "steps": ["string"]
}
Rules:
- Ingredient IDs: i001, i002, i003... 
- Ingredient category is inferred from the name — never ask the user
- duration_minutes is an integer
- category must be one of the exact enum values listed
- steps is an ordered array of plain strings`;

function isYouTubeUrl(url: string): boolean {
  return /^https?:\/\/(www\.)?(youtube\.com\/watch|youtu\.be\/)/.test(url);
}

async function fetchArticleContent(url: string): Promise<string> {
  try {
    const response = await fetch(url);
    const html = await response.text();
    return html
      .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "")
      .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, "")
      .replace(/<[^>]+>/g, " ")
      .replace(/\s+/g, " ")
      .trim()
      .slice(0, 8000);
  } catch (err) {
    throw new Error(`Failed to fetch URL content: ${err.message}`);
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    let body;
    try {
      body = await req.json();
    } catch (jsonErr) {
      return new Response(
        JSON.stringify({ error: "Invalid JSON format received in request body", details: jsonErr.message }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { mode, input } = body;
    if (!mode || !input) {
      return new Response(
        JSON.stringify({ error: "Missing mode or input fields in request payload" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "GEMINI_API_KEY environment variable is missing from Supabase Vault." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── Build Gemini request parts based on mode ──────────────────────────
    let parts: object[];

    if (mode === "url" && isYouTubeUrl(input)) {
      // YouTube: pass directly as a fileData URI — Gemini fetches & understands it natively
      parts = [
        {
          fileData: {
            fileUri: input,
          },
        },
        {
          text: "Extract the recipe from this YouTube video and return it as JSON following the schema in your instructions.",
        },
      ];
    } else if (mode === "url") {
      // Regular article: scrape HTML and pass as text
      const articleText = await fetchArticleContent(input);
      parts = [{ text: articleText }];
    } else {
      // Plain text paste
      parts = [{ text: input }];
    }

    const geminiResponse = await fetch(`${GEMINI_URL}?key=${apiKey}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        system_instruction: { parts: [{ text: SYSTEM_PROMPT }] },
        contents: [{ parts }],
        generationConfig: {
          temperature: 0.1,
          maxOutputTokens: 2048,
          responseMimeType: "application/json",
        },
      }),
    });

    if (!geminiResponse.ok) {
      const errorDetails = await geminiResponse.text();
      return new Response(
        JSON.stringify({ error: "Gemini API rejected request", status: geminiResponse.status, details: errorDetails }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const geminiData = await geminiResponse.json();
    let rawText = geminiData.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

    if (rawText.includes("```")) {
      rawText = rawText.replace(/```json|```/g, "").trim();
    }

    let recipe;
    try {
      recipe = JSON.parse(rawText);
    } catch (parseErr) {
      return new Response(
        JSON.stringify({ error: "Gemini output failed JSON parsing", rawOutput: rawText, details: parseErr.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(JSON.stringify(recipe), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (e) {
    return new Response(
      JSON.stringify({ error: "Unhandled exception in edge function", message: e.message, stack: e.stack }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});