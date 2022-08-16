import { Controller } from "@hotwired/stimulus"

// Using firebase v9 compatibility until firebaseui gets updated to work with
// firebase v9 modules:
import firebase from "@firebase/app-compat"
import "@firebase/auth-compat"
import * as firebaseui from "firebaseui"

const signInOptions = [
  { provider: firebase.auth.EmailAuthProvider.PROVIDER_ID }
]

// Connects to data-controller="sign-in"
export default class extends Controller {
  static targets = [ "sessionForm", "token" ]

  initialize() {
    firebase.initializeApp({
      apiKey: "YOUR_API_KEY",
      authDomain: "YOUR_AUTH_DOMAIN"
    })
  }

  connect() {
    const firebaseAuth = firebase.auth()
    const firebaseAuthUI = new firebaseui.auth.AuthUI(firebaseAuth)
    const signInSuccessWithAuthResult = this.successCallBack.bind(this)

    firebaseAuthUI.start("#auth-container", {
      signInOptions, callbacks: { signInSuccessWithAuthResult }
    })
  }

  successCallBack(authResult) {
    authResult.user.getIdToken(true).then(token => {
      this.tokenTarget.value = token
      this.sessionFormTarget.submit()
    })

    return false
  }
}
