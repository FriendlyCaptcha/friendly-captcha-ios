import express from "express";
import { FriendlyCaptchaClient } from "@friendlycaptcha/server-sdk";

const app = express();
const port = process.env.PORT || 3600;

const FRC_SITEKEY = process.env.FRC_SITEKEY;
const FRC_API_KEY = process.env.FRC_API_KEY;

// Optionally we can pass in custom endpoints to be used, such as "eu".
// We default to `global` here.
const FRC_SITEVERIFY_ENDPOINT = process.env.FRC_SITEVERIFY_ENDPOINT || "global";

if (!FRC_SITEKEY || !FRC_API_KEY) {
  console.error(
    "Please set the FRC_SITEKEY and FRC_API_KEY environment values before running this example to your Friendly Captcha sitekey and API key respectively.",
  );
  process.exit(1);
}

const frcClient = new FriendlyCaptchaClient({
  apiKey: FRC_API_KEY,
  sitekey: FRC_SITEKEY,
  siteverifyEndpoint: FRC_SITEVERIFY_ENDPOINT,
});

app.use(express.json());

app.post("/login", async (req, res) => {
  console.log("Received login request");
  const frcCaptchaResponse = req.body["frc-captcha-response"];

  const result = await frcClient.verifyCaptchaResponse(frcCaptchaResponse);
  if (!result.wasAbleToVerify()) {
    // In this case we were not actually able to verify the response embedded in the form, but we may still want to accept it.
    // It could mean there is a network issue or that the service is down. In those cases you generally want to accept submissions anyhow.
    // That's why we use `shouldAccept()` below to actually accept or reject the form submission. It will return true in these cases.

    if (result.isClientError()) {
      // Something is wrong with our configuration, check your API key!
      // Send yourself an alert to fix this! Your site is unprotected until you fix this.
      console.error("CAPTCHA CONFIG ERROR: ", result.getErrorCode(), result.getResponseError());
    } else {
      console.error("Failed to verify captcha response: ", result.getErrorCode(), result.getResponseError());
    }
  }

  if (!result.shouldAccept()) {
    res.json({"success": false, "message": "Captcha invalid, please try again."});
    res.status(400);
    return;
  }

  // We don't actually check the username or password in this demo, we only check the
  // captcha response. Normally that check would be done here.
  res.json({"success": true, "message": "Login successful!"});
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
