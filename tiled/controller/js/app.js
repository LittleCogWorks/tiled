import {
	updateControllerState,
	stateHint,
	resetVoteState,
	state,
	ControllerState
} from "./state.js";

import { el } from "./dom.js";
import { bindEvents } from "./events.js";
import {
	render,
	applySliderReveal,
	resetSliderButtons
} from "./ui.js";
import {
	log,
	hydrate,
} from "./actions.js";

import {
	STORAGE_KEY
} from "./constants.js";

function init() {
	hydrate();
	bindEvents();
	render();
	log("Controller loaded");
}


init();
