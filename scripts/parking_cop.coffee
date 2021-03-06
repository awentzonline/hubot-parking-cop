# Description:
#   Parking cop tells you who's parking in your spot.
#
# Commands:
#   hubot bust <license-plate> - Notifies the owner of the car with that plate.
#   hubot refresh - Download the latest plate information. This also happens automatically every day.

async = require 'async'
GoogleSpreadsheet = require 'google-spreadsheet'

PARKING_SPREADSHEET_ID = process.env.PARKINGCOP_SPREADSHEET_ID
GOOGLE_CREDS = {
  client_email: process.env.PARKINGCOP_CLIENT_EMAIL,
  private_key: process.env.PARKINGCOP_PRIVATE_KEY
}
UPDATE_PLATE_LOOKUP_INTERVAL = 1000 * 60 * 60 * 8  # 8 hours
PLATE_FIELD = process.env.PARKINGCOP_PLATE_FIELD || 'plate'
SLACK_USER_FIELD = process.env.PARKINGCOP_NAME_FIELD || 'name'

PLATE_LOOKUP = {}
updatePlateLookup = () ->
  doc = new GoogleSpreadsheet PARKING_SPREADSHEET_ID
  sheet = null

  async.series([
    # authenticate
    (step) ->
      doc.useServiceAccountAuth(GOOGLE_CREDS, step)

    # load spreadsheet info
    (step) ->
      doc.getInfo((err, info) ->
        sheet = info.worksheets[0]
        if err
          console.log err
        else
          step()
      )

    # load rows into plate lookup
    (step) ->
      sheet.getRows({
        offset: 1,
        limit: sheet.rowCount,
      }, (err, rows) ->
        if err
          console.log err
        else
          PLATE_LOOKUP = {}
          rows.forEach((row) ->
            thisPlate = normalizePlate(row[PLATE_FIELD])
            if thisPlate
              PLATE_LOOKUP[thisPlate] = formatSlackName(row[SLACK_USER_FIELD])
          )
          console.log PLATE_LOOKUP
      )
      step()
  ])

lookupPlate = (plateNumber) ->
  return PLATE_LOOKUP[normalizePlate(plateNumber)]

formatSlackName = (fullName) ->
  return fullName.trim().toLowerCase().replace(' ', '.')

normalizePlate = (plate) ->
  return plate.trim().toLowerCase().replace(' ', '').replace('-', '')

module.exports = (robot) ->
  robot.respond /bust( +)(.+)/i, (res) ->
    licenseNumber = res.match[2]
    owner = lookupPlate(licenseNumber)
    if owner
      user = robot.adapter.client.rtm.dataStore.getUserByName owner
      if user
        robot.messageRoom user.id, "Please move your car. Have a lawful day."
        res.reply "I have notifed the owner. Have a lawful day."
      else
        console.log "Plate '#{licenseNumber}' has no owner"
        res.reply "I recognize that plate but can't find the owner."
    else
      res.reply "I don't recognize the license plate #{licenseNumber}"

  robot.respond /refresh/i, (res) ->
    res.reply "Refreshing data from Google spreadsheet #{PARKING_SPREADSHEET_ID}"
    updatePlateLookup()


# fire it up
updatePlateLookup()
setInterval(updatePlateLookup, UPDATE_PLATE_LOOKUP_INTERVAL)
