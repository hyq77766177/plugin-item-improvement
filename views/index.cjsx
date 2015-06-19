{React, ReactBootstrap} = window
{Panel, Button, Input, Col, Grid, Row, Table} = ReactBootstrap
Divider = require './divider'
path = require 'path-extra'
fs = require "fs-extra"
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
        <Divider text="日期设置" />
        <Grid className='vertical-center'>
          <Col xs={2}>选择日期</Col>
          <Col xs={3}>
            <Input id='sortbase' type='select' bsSize='small' defaultValue={day} onChange={@handleKeyChange}>
              <option value=0>星期日</option>
              <option value=1>星期一</option>
              <option value=2>星期二</option>
              <option value=3>星期三</option>
              <option value=4>星期四</option>
              <option value=5>星期五</option>
              <option value=6>星期六</option>
            </Input>
          </Col>
        </Grid>
        <Divider text="改修信息" />
        <Grid>
          <Table striped condensed hover id="main-table">
          <thead className="item-table">
            <tr>
              <th width="150" >　　　装备类型</th>
              <th width="250" >装备名称</th>
              <th width="150" >二号舰娘</th>
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
