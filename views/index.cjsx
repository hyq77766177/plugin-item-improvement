{React, ReactBootstrap} = window
{Panel, Button, Nav, NavItem, Col, Grid, Row, Table} = ReactBootstrap
Divider = require './divider'
path = require 'path-extra'
fs = require "fs-extra"
i18n = require 'i18n'
{__} = i18n
i18n.configure
  locales: ['en-US', 'ja-JP', 'zh-CN']
  defaultLocale: 'zh-CN'
  directory: path.join(__dirname, '..', 'i18n')
  updateFiles: false
  indent: "\t"
  extension: '.json'
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
  handleKeyChange: (key) ->
    @getList(key)
    @setState
      dayName: key
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
          <Col xs={12}>
            <Nav bsStyle="pills" activeKey={@state.dayName} onSelect={@handleKeyChange}>
              <NavItem eventKey={0}>{__ "Sunday"}</NavItem>
              <NavItem eventKey={1}>{__ "Monday"}</NavItem>
              <NavItem eventKey={2}>{__ "Tuesday"}</NavItem>
              <NavItem eventKey={3}>{__ "Wednesday"}</NavItem>
              <NavItem eventKey={4}>{__ "Thursday"}</NavItem>
              <NavItem eventKey={5}>{__ "Friday"}</NavItem>
              <NavItem eventKey={6}>{__ "Saturday"}</NavItem>
            </Nav>
          </Col>
        </Grid>
        <Divider text={__ "Improvement information"} />
        <Grid>
          <Table striped condensed hover id="main-table">
          <thead className="item-table">
            <tr>
              <th width="150" >　　　{__ "Type"}</th>
              <th width="250" >{__ "Name"}</th>
              <th width="200" >{__ "2nd Ship"}</th>
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
