import { el } from "./dom.js";
import { state } from "./state.js";
import {
	connect,
	disconnect
} from "./network.js";
import {
	joinLobby,
	sendReady,
	sendOverlayContinue,
	sendSliderClick,
	beginGuessFlow,
	submitGuess,
	cancelGuessFlow,
	sendVote,
	toggleDebugMode,
	persist
} from "./actions.js";


export function bindEvents() {
	el.connectBtn.addEventListener("click", connect);
	el.disconnectBtn.addEventListener("click", () => disconnect(true));
	el.debugToggleBtn.addEventListener("click", toggleDebugMode);
	el.joinBtn.addEventListener("click", joinLobby);
	el.readyBtn.addEventListener("click", sendReady);
	el.continueBtn.addEventListener("click", sendOverlayContinue);
	el.startGuessBtn.addEventListener("click", beginGuessFlow);
	el.guessSubmitBtn.addEventListener("click", submitGuess);
	el.guessCancelBtn.addEventListener("click", cancelGuessFlow);
	el.voteAcceptBtn.addEventListener("click", () => sendVote(true));
	el.voteRejectBtn.addEventListener("click", () => sendVote(false));
	el.sliderButtons.forEach((button) => {
		button.addEventListener("click", () => {
			const idx = Number(button.dataset.index || -1);
			sendSliderClick(idx);
		});
	});
	el.guessInput.addEventListener("keydown", (event) => {
		if (event.key === "Enter") {
			submitGuess();
		}
	});

	[el.hostInput, el.nameInput, el.avatarInput].forEach((input) => {
		input.addEventListener("change", persist);
		input.addEventListener("blur", persist);
	});
}