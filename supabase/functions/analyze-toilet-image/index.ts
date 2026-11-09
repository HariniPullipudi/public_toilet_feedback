// Supabase Edge Function: analyze-toilet-image
// Analyzes toilet facility photos using Google Gemini Vision API
// Securely keeps API keys on the server side

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface RequestPayload {
  imageBase64?: string;
  mimeType?: string;
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const geminiApiKey = Deno.env.get("GEMINI_API_KEY");

    if (!geminiApiKey) {
      return new Response(
        JSON.stringify({
          is_success: false,
          error: "GEMINI_API_KEY secret is not set in Supabase project secrets.",
          explanation: "Please configure your GEMINI_API_KEY in the Supabase Dashboard -> Project Settings -> Edge Functions -> Secrets.",
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        }
      );
    }

    const { imageBase64, mimeType = "image/jpeg" }: RequestPayload = await req.json();

    if (!imageBase64) {
      return new Response(
        JSON.stringify({
          is_success: false,
          error: "Missing imageBase64 in request body.",
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        }
      );
    }

    // Call Gemini 1.5 Flash Vision Endpoint
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`;

    const promptText = `
You are an expert civic sanitation auditor inspecting public toilet facilities under UN Sustainable Development Goal 6 (Clean Water & Sanitation).
Examine this photograph and analyze the condition for:
1. Litter or trash on the floor
2. Overflowing or missing waste bins
3. Dirty toilet bowl, urinal, or sink surface stains
4. Standing or pooled water on the floor, tap leakages
5. Damaged stall doors, broken handles, or missing soap

Respond strictly in valid JSON format matching this schema:
{
  "is_success": true,
  "suggested_category": "Dirty Surfaces" | "Bad Odour" | "Lack of Water" | "Lack of Soap" | "Overflowing Bins" | "Damaged Facilities" | "Poor Accessibility" | "Other",
  "suggested_cleanliness_rating": <integer from 1 to 5, where 1 is severely unsanitary and 5 is clean>,
  "detected_issues": ["<short string description of each visible issue>"],
  "explanation": "<2-3 sentence clear explanation of visible hygiene conditions>",
  "disclaimer": "Notice: AI vision analysis is an automated visual estimation and should be treated as an initial suggestion, not a definitive cleanliness or safety determination."
}
Do not wrap in markdown or backticks. Return raw JSON only.
`;

    const geminiResponse = await fetch(geminiUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              { text: promptText },
              {
                inline_data: {
                  mime_type: mimeType,
                  data: imageBase64,
                },
              },
            ],
          },
        ],
        generationConfig: {
          temperature: 0.2,
          maxOutputTokens: 800,
        },
      }),
    });

    if (!geminiResponse.ok) {
      const errorText = await geminiResponse.text();
      return new Response(
        JSON.stringify({
          is_success: false,
          error: `Gemini API error: ${errorText}`,
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: geminiResponse.status,
        }
      );
    }

    const geminiData = await geminiResponse.json();
    const candidateText =
      geminiData?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

    // Clean any accidental markdown backticks
    const cleanedText = candidateText
      .replace(/```json/gi, "")
      .replace(/```/g, "")
      .trim();

    const parsedJson = JSON.parse(cleanedText);

    return new Response(JSON.stringify(parsedJson), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    return new Response(
      JSON.stringify({
        is_success: false,
        error: error.message || String(error),
        disclaimer: "AI analysis could not complete due to an exception.",
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});
