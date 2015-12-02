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

DB = fs.readJsonSync path.join(__dirname, "..", "data.json")

ItemInfoRow = React.createClass
  render: ->
    <tr className={if @props.highlight then "highlight"} onClick={@props.onClick}>
      <td style={{paddingLeft: 10+'px'}}>
        <img src={path.join(ROOT, 'assets', 'img', 'slotitem', @props.icon)} />
        {@props.type}
      </td>
      <td>{@props.name}</td>
      <td>{@props.hisho}</td>
    </tr>

ItemInfoArea = React.createClass
  getRows: ->
    {day} = @state
    key = Math.pow(2, 6 - day)
    rows = []
    for types in DB
      for names in types.items
        flag = 0
        hishos = ""
        for kanmusu in names.hisho
          if (Math.floor(kanmusu.day / key) % 2 == 1)
            flag = 1
            hishos = hishos + kanmusu.hisho + "　"
        highlight = names.name in @state.highlights
        if flag
          row =
            icon: types.icon
            type: types.type
            name: names.name
            hisho: hishos
            highlight: highlight
          rows.push row
    return rows
  getInitialState: ->
    day = (new Date).getUTCDay()
    if (new Date).getUTCHours() >= 15
      day = (day + 1) % 7

    rows:[]
    day: day
    highlights: config.get('plugin.ItemImprovement.highlights', [])
  handleKeyChange: (key) ->
    @setState
      day: key
  handleClickItem: (name) ->
    {highlights} = @state
    if name in highlights
      highlights = highlights.filter (v) -> v != name
    else
      highlights.push(name)
    config.set('plugin.ItemImprovement.highlights', highlights)
    @setState
      highlights: highlights

  render: ->
    rows = @getRows()
    <Grid id="item-info-area">
      <div id='item-info-settings'>
        <Divider text={__ "Weekday setting"} />
        <Grid className='vertical-center'>
          <Col xs={12}>
            <Nav bsStyle="pills" activeKey={@state.day} onSelect={@handleKeyChange}>
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
            if rows?
              for row, index in rows
                <ItemInfoRow
                  icon = {row.icon}
                  type = {row.type}
                  name = {row.name}
                  hisho = {row.hisho}
                  highlight = {row.highlight}
                  onClick = {@handleClickItem.bind(@, row.name)}
                />
            }
          </tbody>
          </Table>
        </Grid>
      </div>
    </Grid>

React.render <ItemInfoArea />, $('item-improvement')
