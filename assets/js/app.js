import css from "../css/app.css";
import "phoenix_html"
import {LiveSocket, debug} from "phoenix_live_view"

let liveSocket = new LiveSocket("/live")
liveSocket.connect()


document.addEventListener('DOMContentLoaded', function() {
  let characterForm = document.querySelector(".character-form")

  function updateCharacterDisplay() {
    let bodyDisplay = characterForm.querySelector(".character .body")
    let eyesDisplay = characterForm.querySelector(".character .eyes")

    let bodyInput = characterForm.querySelector("input[name='body']")
    let eyesInput = characterForm.querySelector("input[name='eyes']")

    let bodyValue = bodyInput.getAttribute("value")
    let eyesValue = eyesInput.getAttribute("value")

    bodyDisplay.style.backgroundImage = `url('/images/body_${bodyValue}.png')`
    eyesDisplay.style.backgroundImage = `url('/images/eyes_${eyesValue}.png')`
  }

  function updatePart(name, direction) {
    let input = characterForm.querySelector(`input[name='${name}']`)
    let value = input.getAttribute("value")
    value = parseInt(value)
    const newValue = value + direction
    input.setAttribute("value", newValue)

    updateCharacterDisplay()
  }

  function addEvents() {
    let bodyLeft = document.querySelector(".character-form .body-left")
    let bodyRight = document.querySelector(".character-form .body-right")
    let eyesLeft = document.querySelector(".character-form .eyes-left")
    let eyesRight = document.querySelector(".character-form .eyes-right")

    bodyLeft.addEventListener("click", function() {
      updatePart("body", -1)
    })

    bodyRight.addEventListener("click", function() {
      updatePart("body", 1)
    })

    eyesLeft.addEventListener("click", function() {
      updatePart("eyes", -1)
    })

    eyesRight.addEventListener("click", function() {
      updatePart("eyes", 1)
    })
  }

  if (characterForm) {
    addEvents()
    updateCharacterDisplay()
  }
}, false);
