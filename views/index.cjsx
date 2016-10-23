fs = require "fs-extra"
path = require 'path-extra'
{React, ReactBootstrap} = window
{Panel, Button, Nav, NavItem, Col, Grid, Row, Table, Collapse} = ReactBootstrap
Divider = require './divider'
{SlotitemIcon} = require "#{ROOT}/views/components/etc/icon"
{sortBy, clone} = require 'lodash'
inputDepreacted = ReactBootstrap.Checkbox?
if inputDepreacted
  Input = ReactBootstrap.Checkbox
else
  Input = ReactBootstrap.Input

__ = i18n.main.__.bind(i18n.main)
try
  require('poi-plugin-translator')
catch error
  console.log error

DATA = fs.readJsonSync path.join(__dirname, "..", "assets", "data.json")
DATA = sortBy DATA, ['icon', 'id']

ItemInfoRow = React.createClass
  handleExpanded: ->
    @props.setExpanded(!@props.rowExpanded)
  render: ->
    <tr>
      <td style={{paddingLeft: 20}}>
        <Input type="checkbox"
               className={if inputDepreacted then 'new-checkbox' else ''}
               checked={@props.highlight}
               onChange={@props.clickCheckbox} />
        <SlotitemIcon slotitemId={@props.icon} />
        {@props.type}
      </td>
      <td onClick = {@handleExpanded}>{@props.name}</td>
      <td>{@props.hisho unless @props.rowExpanded}</td>
    </tr>

DetailRow = React.createClass
  render: ->
    <Collapse in = {@props.rowExpanded}>
      <tr>
        <td colSpan = 3>
          Test!
        </td>
      </tr>
    </Collapse>

ItemInfoArea = React.createClass
  getRows: ->
    {day} = @state
    rows = []
    for item in DATA
      hishos = []
      for improvement in item.improvement
        for req in improvement.req
          for secretary in req.secretary
            if req.day[day]
              hishos.push __ window.i18n.resources.__ secretary
      highlight = item.id in @state.highlights
      if hishos.length > 0
        row =
          id: item.id
          icon: item.icon
          type: window.i18n.resources.__ item.type
          name: window.i18n.resources.__ item.name
          hisho: hishos.join(' / ')
          highlight: highlight
        rows.push row
    return rows
  getInitialState: ->
    day = (new Date).getUTCDay()
    if (new Date).getUTCHours() >= 15
      day = (day + 1) % 7
    day: day
    highlights: config.get('plugin.ItemImprovement.highlights', [])
    rowsExpanded: {}
  handleKeyChange: (key) ->
    @setState
      day: key
  handleClickItem: (id) ->
    {highlights} = @state
    if id in highlights
      highlights = highlights.filter (v) -> v != id
    else
      highlights.push(id)
    config.set('plugin.ItemImprovement.highlights', highlights)
    @setState
      highlights: highlights
  handleRowExpanded: (id, expanded) ->
    rowsExpanded = clone(@state.rowsExpanded)
    rowsExpanded[id] = expanded
    @setState
      rowsExpanded: rowsExpanded 

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
          <Table bordered condensed hover id="main-table">
          <thead className="item-table">
            <tr>
              <th width="200" ><div style={paddingLeft: '55px'}>{__ "Type"}</div></th>
              <th width="250" >{__ "Name"}</th>
              <th width="200" >{__ "2nd Ship"}</th>
            </tr>
          </thead>
          <tbody>
          { 
            if rows?
              results = []
              for row, index in rows
                if row.highlight
                  rowExpanded = @state.rowsExpanded[row.id] or false
                  results.push <ItemInfoRow
                    key = {row.id}
                    icon = {row.icon}
                    type = {row.type}
                    name = {row.name}
                    hisho = {row.hisho}
                    highlight = {row.highlight}
                    clickCheckbox = {@handleClickItem.bind(@, row.id)}
                    rowExpanded = {rowExpanded}
                    setExpanded = {@handleRowExpanded.bind(@, row.id)}
                  />
                  results.push <DetailRow
                    key = {"detail-#{row.id}"}
                    rowExpanded = {rowExpanded}
                  />
              for row, index in rows
                if not row.highlight
                  rowExpanded = @state.rowsExpanded[row.id] or false
                  results.push <ItemInfoRow
                    key = {row.id}
                    icon = {row.icon}
                    type = {row.type}
                    name = {row.name}
                    hisho = {row.hisho}
                    highlight = {row.highlight}
                    clickCheckbox = {@handleClickItem.bind(@, row.id)}
                    rowExpanded = {rowExpanded}
                    setExpanded = {@handleRowExpanded.bind(@, row.id)}
                  />
                  results.push <DetailRow
                    key = {"detail-#{row.id}"}
                    rowExpanded = {rowExpanded}
                  />
              results
            }
          </tbody>
          </Table>
        </Grid>
      </div>
    </Grid>

ReactDOM.render <ItemInfoArea />, $('item-improvement')