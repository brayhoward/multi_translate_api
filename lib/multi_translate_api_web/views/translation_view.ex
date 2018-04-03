defmodule MultiTranslateApiWeb.TranslationView do
  use MultiTranslateApiWeb, :view

  def render("translations.json", %{translations: translations}) do
    %{data: render_many(translations, __MODULE__, "translation.json")}
  end

  def render("translation.json", %{translation: trans}) do
    %{
      text: trans.text,
      language: trans.language
    }
  end
end