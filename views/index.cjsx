{React, ReactBootstrap, jQuery} = window
{Panel, Button, Input, Col, Grid, Row, Table} = ReactBootstrap
Divider = require './divider'

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
    path = require 'path'
    switch e.target.value
      when "sun"
			     pp = path.join(__dirname, "..", "sun.txt")
        break;
      when "mon"
           pp = path.join(__dirname, "..", "mon.txt")
           break;
      when "tue"
           pp = path.join(__dirname, "..", "tue.txt")
           break;
      when "wed"
           pp = path.join(__dirname, "..", "wed.txt")
           break;
      when "thu"
           pp = path.join(__dirname, "..", "fri.txt")
           break;
      when "fri"
           pp = path.join(__dirname, "..", "fri.txt")
           break;
      when "sat"
           pp = path.join(__dirname, "..", "sat.txt")
           break;
    fs = require "fs"
    contents = fs.readFileSync(pp,"utf8")
    strs = contents.split("\n")
    rows = []
    for item in strs
      items = item.split(",")
      row =
        type: items[0]
        name: items[1]
        hisho: items[2]
      rows.push row
    @setState
      rows: rows
  render: ->

    <Grid id="item-info-area">
      <div id='item-info-settings'>
        <Divider text="装备改修" />
        <Grid className='vertical-center'>
          <Col xs={2}>选择日期</Col>
          <Col xs={2}>
            <Input id='sortbase' type='select' placeholder='sun' onChange={@handleKeyChange}>
              <option value='sun'>日</option>
              <option value='mon'>月</option>
              <option value='tue'>火</option>
              <option value='wed'>水</option>
              <option value='thu'>木</option>
              <option value='fri'>金</option>
              <option value='sat'>土</option>
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
