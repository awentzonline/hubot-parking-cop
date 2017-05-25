# hubot-parking-cop
Find out who's parking in your spot.

Parking Cop is configured with a Google Sheet:tm: of user names and license plates.

### Usage
```@parkingcop bust <license-plate-number>```
e.g.
```@parkingcop bust ROMAN-1```

If Parking Cop knows the license plate, it will acknowledge your request and private message the offender.

### Configuration

The following environment variables are expected to be set:
 * PARKING_SPREADSHEET_ID - the id of your configuration spreadsheet
 * PARKINGCOP_CLIENT_EMAIL - see https://www.npmjs.com/package/google-spreadsheet for how to set up an api user
 * PARKINGCOP_PRIVATE_KEY - see https://www.npmjs.com/package/google-spreadsheet for how to set up an api user

The following environment variables are optional and specific to your data:
 * PARKINGCOP_NAME_FIELD - field containing user names (default: "name")
 * PARKINGCOP_PLATE_FIELD - field containing license plates (default: "plate")
