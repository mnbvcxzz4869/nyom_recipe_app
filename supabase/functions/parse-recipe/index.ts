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
    }
  ],
  "steps": ["string"]
}
Rules:
- If you cannot confidently extract a recipe from the input, return ONLY: {"error": "Could not extract recipe"}
- Ingredient IDs: i001, i002, i003...
- Ingredient names must always start with an uppercase letter (e.g. "Garlic cloves", not "garlic cloves")
- Ingredient category is inferred from the name — never ask the user
- Each ingredient must be a single item — never combine two ingredients into one entry (e.g. never "Salt and pepper")
- quantity must always include the unit (e.g. "2 cloves", "1 cup", "200g") — never a bare number
- duration_minutes must be an integer — if it cannot be determined, default to 30
- category must be one of the exact enum values listed — if ambiguous, pick the category of the most prominent ingredient
- steps is an ordered array of plain strings
- Each step must be a complete, actionable sentence — split compound actions into separate steps`;

function isYouTubeUrl(url: string): boolean {
  return /^https?:\/\/(www\.)?(youtube\.com\/watch|youtu\.be\/)/.test(url);
}

function getYoutubeThumbnail(url: string): string | null {
  const match = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})/);
  return match ? `https://img.youtube.com/vi/${match[1]}/maxresdefault.jpg` : null;
}

async function fetchArticleContent(url: string): Promise<{ text: string; imageUrl: string | null }> {
  try {
    const response = await fetch(url);
    const html = await response.text();

    const ogImageMatch = html.match(/<meta[^>]+property=["']og:image["'][^>]+content=["']([^"']+)["']/i)
      ?? html.match(/<meta[^>]+content=["']([^"']+)["'][^>]+property=["']og:image["']/i);
    const imageUrl = ogImageMatch?.[1] ?? null;

    const text = html
      .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "")
      .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, "")
      .replace(/<[^>]+>/g, " ")
      .replace(/\s+/g, " ")
      .trim()
      .slice(0, 8000);

    return { text, imageUrl };
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
    let extractedImageUrl: string | null = null;

    if (mode === "url" && isYouTubeUrl(input)) {
      extractedImageUrl = getYoutubeThumbnail(input); // ← add this
      parts = [
        { fileData: { fileUri: input } },
        { text: "Extract the recipe from this YouTube video and return it as JSON following the schema in your instructions." },
      ];
    } else if (mode === "url") {
      const { text, imageUrl } = await fetchArticleContent(input);
      extractedImageUrl = imageUrl;
      parts = [{ text }];
    } else if (mode === "categorize") {
      const names = JSON.parse(input) as string[];
      parts = [{ text: `Given these ingredient names, return ONLY a valid JSON object mapping each name to its category. Categories: "produce", "protein", "dairy", "pantry". No markdown, no explanation. Example: { "Garlic cloves": "produce", "Chicken breast": "protein" } Ingredients: ${JSON.stringify(names)}` }];
    } else {
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
      recipe.image_url = extractedImageUrl; 
    } catch (parseErr) {
      return new Response(
        JSON.stringify({ error: "Gemini output failed JSON parsing", rawOutput: rawText, details: parseErr.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (recipe.error) {
      return new Response(
        JSON.stringify({ error: recipe.error }),
        { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } }
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