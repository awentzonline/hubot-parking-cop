# hubot-parking-cop
Find out who's parking in your spot.

Parking Cop is configured with a google spreadsheet of user names and license plates.

### Usage
```@parkingcop bust <license-plate-number>```
e.g.
```@parkingcop bust ROMAN-1```

If Parking Cop knows the license plate, it will @mention the offender.

### Configuration

The following environment variables are expected to be set:
 * PARKING_SPREADSHEET_ID - the id of your configuration spreadsheet
 * PARKINGCOP_CLIENT_EMAIL - see https://www.npmjs.com/package/google-spreadsheet for how to set up an api user
 * PARKINGCOP_PRIVATE_KEY - see https://www.npmjs.com/package/google-spreadsheet for how to set up an api user

The target spreadsheet should have at least two columns named "plate" and "name".
Plate is the user's license plate and name is the full name of the user.
