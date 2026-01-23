// Entry point for the build script in your package.json

import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

const application = Application.start()
const context = require.context("./controllers", true, /.js$/)
application.load(definitionsFromContext(context))

import { _ } from "lodash";

import "./src/forms_helper";

require("trix");
require("@rails/activestorage");
require("@rails/actiontext");


