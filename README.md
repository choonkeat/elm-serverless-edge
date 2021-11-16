_NOTE: this repo is an early iteration of [elm-webapp](https://github.com/choonkeat/elm-webapp). ideally we re-introduce a cloudflare workers runtime to [elm-webapp](https://github.com/choonkeat/elm-webapp) instead_

# Elm on Cloudflare Workers with KV

Elm is a perfect fit actually, since you can hardly do anything other than HTTP and accessing the Cloudflare KV store.

<img width="1046" alt="Screenshot 2019-09-21 at 10 42 51 AM" src="https://user-images.githubusercontent.com/473/65366938-fbbbc680-dc5c-11e9-9624-453041d63e69.png">


# Setup

1. After logging into cloudflare click on `Get started with Workers`, or go to `https://dash.cloudflare.com/{account_id}/workers/kv/namespaces`
1. Click on `KV` and add a namespace; copy and paste the `id` into `wrangler.toml` under `[[kv-namespaces]] > id`
1. Click on `Workers` tab on top and create a worker; set the worker name in your wrangler.toml
1. Click on `{} Editor` > `KV` tab > `+ Add binding` button to bind your KV namespace to a JS global variable name (the variable name can be different from the namespace name)
    - i _think_ you'll need to `Save and deploy` button below for it to take effect

After these are setup, you can `make preview` locally; your browser will automatically load a page running your worker on Cloudflare.
