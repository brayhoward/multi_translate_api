# MultiTranslateApi
> translation api built for use with a [React Native application that can be found here](https://expo.io/@brayhoward/multi-translate)

This api intigrates with the Microsoft Azure translation api. It creates a protocol for translating an english string into multiple languages concurrently.


## Up and running

To run locally you must create a `config/dev.secret.exs` and confiure the app to use your personal Azure tranlation api key
and set a client_auth_key used for validating the source of incoming requests.
**Example config:**
_dev.secret.exs_
```
use Mix.Config

config :multi_translate_api,
  azure_translator_api_key: "you_azure_api_key_goes_here",
  client_auth_key: "generate_a_key_and_place_it_here"

```


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


## Making reqeusts to the API
All request must be sent with and `api-key` header. The value for this header should be the same as the `client_auth_key` configured in _dev.secrete.exs_
`"api-key": "your_client_auth_key"`


There are two endpoints availible for consumption
1. `/api/iso-table`
 Returns a key value data structure with the availible iso codes and the language to code corresponds too.
 **example return:**
 ```
 {
   "zh": "Chinese",
   "vi": "Vietnamese",
   "tr": "Turkish",
   "ru": "Russian",
   "pt": "Portuguese",
   "pl": "Polish",
   "nl": "Dutch",
   "ms": "Malay",
   "ko": "Korean",
   "ja": "Japanese",
   "id": "Italian",
   "hi": "Hindi",
   "fr": "French",
   "fa": "Persian",
   "es": "Spanish",
   "de": "German",
   "bn": "Bengali",
   "ar": "Arabic"
 }
 ```
 
2. `/api/translate?text=Hello&iso_codes="[\"zh\", \"ru\"]"`
 Returns an array of translations based on the query params. The **iso_codes** param is optional; The default behaviour is to return a translation for all availble languages.
 **example return:**
 ```
 [
   {
     "text": "你好",
     "language": "Chinese"
   },
   {
     "text": "Привет",
     "language": "Russian"
   }
 ]
 ```
 
 

## Learn more about Phoenix

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
