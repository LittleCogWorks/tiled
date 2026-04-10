import { el } from "./dom.js";
import {
			state,
			ControllerState,
			stateHint,
			resetVoteState,
			updateControllerState
		} from "./state.js";
import { send } from "./network.js";
import { render, resetSliderButtons } from "./ui.js";
import { STORAGE_KEY } from "./constants.js";

export function log(message) {
	const stamp = new Date().toLocaleTimeString();
	el.logBox.textContent = `[${stamp}] ${message}\n${el.logBox.textContent}`;
}

export function hydrate() {
	const defaultHost = `ws://${window.location.hostname || "127.0.0.1"}:9080`;
	const urlDebug = new URLSearchParams(window.location.search).get("debug");
	const savedRaw = localStorage.getItem(STORAGE_KEY);
	if (!savedRaw) {
		el.hostInput.value = defaultHost;
		state.debugMode = urlDebug === "1";
		return;
	}

	try {
		const saved = JSON.parse(savedRaw);
		el.hostInput.value = saved.host || defaultHost;
		el.nameInput.value = saved.name || "";
		el.avatarInput.value = String(saved.avatarIndex ?? 0);
		state.clientId = saved.clientId || state.clientId;
		state.debugMode = urlDebug === "1" ? true : Boolean(saved.debugMode);
	} catch (_err) {
		el.hostInput.value = defaultHost;
		state.debugMode = urlDebug === "1";
	}
}

export function joinLobby() {
	const name = el.nameInput.value.trim();
	const avatarIndex = Number(el.avatarInput.value || 0);
	if (!name) {
		log("Name is required");
		return;
	}

	persist();
	send("join", {
		name,
		avatar_index: avatarIndex,
		client_id: state.clientId,
	});
}

export function sendReady() {
	state.ready = !state.ready;
	updateControllerState();
	render();
	send("ready", { ready: state.ready, client_id: state.clientId });
}

export function sendOverlayContinue() {
	if (!state.overlayActive) {
		return;
	}
	send("overlay_continue", { client_id: state.clientId });
}

export function sendSliderClick(index) {
	if (index < 0 || index > 8) {
		log(`Invalid slider index ${index}`);
		return;
	}
	if (state.forcedGuess) {
		log("You must submit a guess now");
		return;
	}

	const button = el.sliderButtons.find((b) => Number(b.dataset.index) === index);
	if (button && button.classList.contains("revealed")) {
		return;
	}
	send("slider_click", { index });
}

export function beginGuessFlow() {
	const controlsEnabled = state.connected && state.joined && state.turnStateKnown && state.isYourTurn && !state.overlayActive;
	if (!controlsEnabled) {
		return;
	}
	state.guessMode = true;
	send("guess_start", { client_id: state.clientId });
	render();
	el.guessInput.focus();
}

export function submitGuess() {
	if (!state.guessMode) {
		return;
	}
	const answer = el.guessInput.value.trim();
	if (!answer) {
		log("Guess is empty");
		return;
	}
	send("guess", { answer });
	el.guessInput.value = "";
	state.guessMode = false;
	render();
}

export function cancelGuessFlow() {
	if (state.forcedGuess) {
		return;
	}
	state.guessMode = false;
	el.guessInput.value = "";
	render();
}

export function sendVote(accepted) {
	if (!state.voteActive) {
		log("No active vote");
		return;
	}
	if (!state.voteCanCast) {
		log("You are not eligible to vote this round");
		return;
	}
	if (state.voteSubmitted) {
		return;
	}

	state.voteSubmitted = true;
	state.voteResultText = `Vote submitted: ${accepted ? "Accept" : "Reject"}`;
	updateControllerState();
	render();
	send("vote", { accepted });
}

export function toggleDebugMode() {
	state.debugMode = !state.debugMode;
	persist();
	render();
}

export function persist() {
	const payload = {
		host: el.hostInput.value.trim(),
		name: el.nameInput.value.trim(),
		avatarIndex: Number(el.avatarInput.value || 0),
		clientId: state.clientId,
		debugMode: state.debugMode,
	};
	localStorage.setItem(STORAGE_KEY, JSON.stringify(payload));
}
