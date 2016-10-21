// This script downloads and converts item impovement data from WhoCallsTheFleet Project
// Special thanks to WhoCallsTheFleet and kcwiki
// Tested with es2017 presets
const Promise = require('bluebird')
const fs = Promise.promisifyAll(require('fs-extra'))
const _ = require('lodash')
const request = require('request')

const DATA_URL = 'https://raw.githubusercontent.com/Diablohu/WhoCallsTheFleet/master/app-db/items.json'
const START2_URL = 'https://api.kcwiki.moe/start2'

const parseImprovement = (data, items, ships) => {
  let res = []
  for (let upgrade of data) { // multiple upgrade is possible
    let upg = {}
    upg.upgrade = {}
    if (upgrade.upgrade) {
      let upgradeId
      ;[upgradeId,
      upg.upgrade.level] = upgrade.upgrade
      upg.upgrade.name = items[upgradeId].api_name
    }
    else {
      upg.upgrade = upgrade.upgrade
    }


    upg.req = [] // parse improvement required secretary ships
    for (let req of upgrade.req) {
      let ship = {}
      let secretaryId
      ;[ship.day, secretaryId] = req
      // kai and kai2 are considered same ship, if appeared in the list
      // false means improvable for every ship, giving 0 as secretaryId
      secretaryId = secretaryId ? secretaryId : 0
      if (secretaryId) {
        let _ships = secretaryId.slice(0) // copy the array
        for (let id of secretaryId) {
          let afterShipId = parseInt(ships[id].api_aftershipid)
          if (_.find(secretaryId, (id) => id === afterShipId)) {
            _.remove(_ships, (id) => id === afterShipId)
          }
        }
        secretaryId = _ships
        // ship.after_id = _.map(ship.secretary_id, (id) => parseInt(ships[id].api_aftershipid))
      }
      ship.secretary = secretaryId ? _.map(secretaryId, (id) => ships[id].api_name) : ['None']
      upg.req.push(ship)
    }

    // parse resource necessary, rename resource to consume
    // 3 sub-array stands for: level 1~6, level 6~10, upgrade
    // sub-array = [
    //    development material,
    //    guarantedd development material,
    //    improvement material,
    //    guaranteed improvement material,
    //    id of items to consume,
    //    count of items to consume]
    // if not upgradable, last aub-array will be all 0
    upg.consume = {}
    ;[upg.consume.fuel,
    upg.consume.ammo,
    upg.consume.steel,
    upg.consume.bauxite] = upgrade.resource[0]

    upg.consume.material = _.map(upgrade.resource.slice(1), (arr) => {
      let itemName = arr[4] ? items[arr[4]].api_name : ''
      let itemIcon = arr[4] ? items[arr[4]].api_type[3] : 0
      return {
        development: arr.slice(0, 2),
        improvement: arr.slice(2, 4),
        item: {
          // id: arr[4],
          icon: itemIcon,
          name: itemName,
          count: arr[5]
        }
      }
    })

    res.push(upg)
  }
  return res
}



const download = (URL) => {
  return new Promise((resolve, reject) => {
    request(URL, (err, res, body) => {
      if (err) {
        reject(err)
        return
      }
      console.log(`finished downloading ${URL}`)
      resolve(body)
    })
  })
}


const read = async () => {
  const gameData = await download(START2_URL)
  const start2 = JSON.parse(gameData)
  const items = _.keyBy(start2.api_mst_slotitem, 'api_id')
  const itemType = _.keyBy(start2.api_mst_slotitem_equiptype, 'api_id')
  const ships = _.keyBy(start2.api_mst_ship, 'api_id')
  const improvementData = await download(DATA_URL)

  let improvement = []
  for (let item of improvementData.split(/\n+/)) {
    if (item) {
      let json = JSON.parse(item)
      if (json.improvable) {
        improvement.push({
          id: json.id,
          type: itemType[items[json.id].api_type[2]].api_name,
          icon: items[json.id].api_type[3],
          name: items[json.id].api_name,
          // name_compare: json.name.ja_jp,
          improvement: parseImprovement(json.improvement, items, ships)
        })
      }
    }
  }
  improvement = _.sortBy(improvement, ['icon', 'id'])
  fs.outputJson('./data.json', improvement, (err) => { if (err) console.log(err) })
}

read()
