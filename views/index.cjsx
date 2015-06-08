{React, ReactBootstrap} = window
{Panel, Button, Input, Col, Grid, Row, Table} = ReactBootstrap
Divider = require './divider'
path = require 'path-extra'
fs = require "fs-extra"
ItemImprovementCheckboxArea = React.createClass
ItemInfoTable = React.createClass
  render: ->
    <tr>
      <td>{@props.type}</td>
      <td>{@props.name}</td>
      <td>{@props.hisho}</td>
    </tr>
ItemInfoArea = React.createClass
  getInitialState: ->
    rows:[]
    dayName: 'sun'
  handleKeyChange: (e) ->
    {rows} = @state
    switch e.target.value
      when "sun"
       key = 64
      when "mon"
       key = 32
      when "tue"
       key = 16
      when "wed"
       key = 8
      when "thu"
       key = 4
      when "fri"
       key = 2
      when "sat"
       key = 1
    pp = path.join(__dirname, "..", "data.json")
    db = fs.readJsonSync(pp, 'utf8')
    rows = []
    for types in db
      for names in types.items
        flag = 0
        hishos = ""
        for kanmusu in names.hisho
          if (Math.floor(kanmusu.day / key) % 2 == 1)
            flag = 1
            hishos = hishos + " " + kanmusu.hisho
        if flag
          row =
            type: types.type
            name: names.name
            hisho: hishos
          rows.push row
    @setState
      rows: rows
  render: ->
    <Grid id="item-info-area">
      <div id='item-info-settings'>
        <Divider text="装备改修" />
        <Grid className='vertical-center'>
          <Col xs={2}>选择日期</Col>
          <Col xs={3}>
            <Input id='sortbase' type='select' placeholder='sun' onChange={@handleKeyChange}>
              <option value='sun'>日曜日</option>
              <option value='mon'>月曜日</option>
              <option value='tue'>火曜日</option>
              <option value='wed'>水曜日</option>
              <option value='thu'>木曜日</option>
              <option value='fri'>金曜日</option>
              <option value='sat'>土曜日</option>
            </Input>
          </Col>
        </Grid>
        <Divider text="" />
        <Grid>
          <Table striped condensed hover id="main-table">
          <thead className="item-table">
            <tr>
              <th className="center">装备类型</th>
              <th className="center">装备名称</th>
              <th className="center">二号舰娘</th>
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
