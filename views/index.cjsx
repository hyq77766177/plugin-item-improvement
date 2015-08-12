{React, ReactBootstrap} = window
{Panel, Button, Input, Col, Grid, Row, Table} = ReactBootstrap
Divider = require './divider'
path = require 'path-extra'
fs = require "fs-extra"
i18n = require '../node-modules/i18n'
{__} = i18n
i18n.configure({
    locales:['en_US', 'ja_JP', 'zh_CN'],
    defaultLocale: 'zh_CN',
    directory: path.join(__dirname, '..', "i18n"),
    updateFiles: false,
    indent: "\t",
    extension: '.json'
})
i18n.setLocale(window.language)

day = (new Date).getUTCDay()
if (new Date).getUTCHours() >= 15
  day = (day + 1) % 7
ItemImprovementCheckboxArea = React.createClass
ItemInfoTable = React.createClass
  render: ->
    <tr>
      <td style={{paddingLeft: 10+'px'}}>
        {
          <img src={
              path.join(ROOT, 'assets', 'img', 'slotitem', @props.icon)
            }
            />
        }
        {@props.type}
      </td>
      <td>{@props.name}</td>
      <td>{@props.hisho}</td>
    </tr>
ItemInfoArea = React.createClass
  getList: (_day) ->
    {rows} = @state
    key = Math.pow(2, 6- _day)
    pp = path.join(__dirname, "..", "data.json")
    db = fs.readJsonSync pp
    rows = []
    for types in db
      for names in types.items
        flag = 0
        hishos = ""
        for kanmusu in names.hisho
          if (Math.floor(kanmusu.day / key) % 2 == 1)
            flag = 1
            hishos = hishos + kanmusu.hisho + "　"
        if flag
          row =
            icon: types.icon
            type: types.type
            name: names.name
            hisho: hishos
          rows.push row
    @setState
      rows: rows
  getInitialState: ->
    rows:[]
    dayName: day
    #@getList(day)
  handleKeyChange: (e) ->
    @getList(e.target.value)
  componentDidMount: ->
    day = (new Date).getUTCDay()
    if (new Date).getUTCHours() >= 15
      day = (day + 1) % 7
    @getList(day)
  componentWillUnmount: ->
    day = (new Date).getUTCDay()
    if (new Date).getUTCHours() >= 15
      day = (day + 1) % 7
    @getList(day)
  render: ->
    <Grid id="item-info-area">
      <div id='item-info-settings'>
        <Divider text={__ "Weekday setting"} />
        <Grid className='vertical-center'>
          <Col xs={2}>{__ "Choose weekday"}</Col>
          <Col xs={3}>
            <Input id='sortbase' type='select' bsSize='small' defaultValue={day} onChange={@handleKeyChange}>
              <option value=0>{__ "Sunday"}</option>
              <option value=1>{__ "Monday"}</option>
              <option value=2>{__ "Tuesday"}</option>
              <option value=3>{__ "Wednesday"}</option>
              <option value=4>{__ "Thursday"}</option>
              <option value=5>{__ "Friday"}</option>
              <option value=6>{__ "Saturday"}</option>
            </Input>
          </Col>
        </Grid>
        <Divider text={__ "Improvement information"} />
        <Grid>
          <Table striped condensed hover id="main-table">
          <thead className="item-table">
            <tr>
              <th width="150" >　　　{__ "Type"}</th>
              <th width="250" >{__ "Name"}</th>
              <th width="150" >{__ "2nd Ship"}</th>
            </tr>
          </thead>
          <tbody>
          {
            if @state.rows?
              printRows = []
              for row in @state.rows
                printRows.push row
              for row, index in printRows
                <ItemInfoTable
                  icon = {row.icon}
                  type = {row.type}
                  name = {row.name}
                  hisho = {row.hisho}
                />
            }
          </tbody>
          </Table>
        </Grid>
      </div>
    </Grid>
React.render <ItemInfoArea />, $('item-improvement')
