// Entry point for the build script in your package.json

import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

const application = Application.start()
const context = require.context("./controllers", true, /.js$/)
application.load(definitionsFromContext(context))

import { _ } from "lodash";

import "./src/forms_helper";

import { clipboard } from "clipboard-polyfill";

require("trix");
// require("@rails/actiontext");
require("@rails/ujs");
require("@rails/activestorage");

// import "@rails/actiontext";
import { AttachmentUpload } from "@rails/actiontext/app/javascript/actiontext/attachment_upload";

addEventListener("trix-attachment-add", event => {
  const { attachment, target } = event

  if (attachment.file) {
    const upload = new AttachmentUpload(attachment, target)
    upload.start()
  }
});
