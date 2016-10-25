import fs from 'fs-extra'
import path from 'path-extra'
import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import FontAwesome from 'react-fontawesome'
import { Button, Nav, NavItem, Col, Grid, Table, Collapse, ButtonGroup, Checkbox } from 'react-bootstrap'
import { Divider } from './divider'
import { SlotitemIcon, MaterialIcon } from 'views/components/etc/icon'
import _ from 'lodash'

const {$, __, __r, config} = window

let data_json = fs.readJsonSync(path.join(__dirname, "..", "assets", "data.json"))
const DATA = _.sortBy(data_json, ['icon', 'id'])
const WEEKDATE = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']

const queryData = (id) => _.find(DATA, (item) => item.id == id)

// React Elements
class ItemInfoRow extends Component {
  handleExpanded = () => {
    return this.props.setExpanded(!this.props.rowExpanded)
  }

  render(){
    return(
      <tr>
        <td style={{paddingLeft: 20}}>
          <Checkbox type="checkbox"
                 className={'new-checkbox'}
                 checked={this.props.highlight}
                 onChange={this.props.clickCheckbox} />
          <SlotitemIcon slotitemId={this.props.icon} />
          {this.props.type}
        </td>
        <td onClick = {this.handleExpanded} className="expandable">{this.props.name}</td>
        <td>{this.props.hisho}</td>
      </tr>
    )
  }
}

const DetailRow = (props) =>{
  let result = []
  let data = queryData(props.id)
  for(let improvement of data.improvement){
    let hishos = []
    for (let req of improvement.req){
      for (let secretary of req.secretary){
        if(req.day[props.day]){
          hishos.push(__(window.i18n.resources.__(secretary)))
        }
      }
    }

    // skip the entry if no secretary availbale for chosen day
    if (hishos.length ==0){
      continue
    }

    if(improvement.upgrade){
      result.push(
        <UpgradeRow
        icon = {improvement.upgrade.icon}
        name = {__r(improvement.upgrade.name)}
        level = {improvement.upgrade.level}
        hishos = {hishos.join(" / ")}
        />
      )
    }

    result.push(<ConsumeRow consume = {improvement.consume}/>)

    improvement.consume.material.forEach((mat, index) =>{
      if (mat.improvement[0]){
        result.push(
          <MatRow
          stage = {index}
          development = {mat.development}
          improvement = {mat.improvement}
          item = {mat.item}
          />
        )
      }
    })
  }

  return(
    <Collapse in = {props.rowExpanded}>
      <tr>
        <td colSpan = {3}>
          <table width ="100%">
          <colgroup>
            <col width="25%"></col>
            <col></col>
          </colgroup>
            <tbody>
              {result}
            </tbody>
          </table>
        </td>
      </tr>
    </Collapse>
  )
}

const Weekday = (props) => {
  return(
    <ButtonGroup bsSize="small">
      {
        props.day.map ((v,i) =>{
          <Button bsStyle={v ? 'success' : ''} active>
            {__(WEEKDATE[i])}
          </Button>
        })
      }
    </ButtonGroup>
  )
}

const UpgradeRow = (props) => {
  let star = ''
  if (props.level){
    star = <span> <FontAwesome name='star' />{` ${props.level}`}</span>
  }
  return(
    <tr>
      <td colSpan={2} className="cell-header">{__("upgrade to")}:
        <SlotitemIcon slotitemId={props.icon} />
        {props.name}
        {star}
        <span> [{props.hishos}]</span>
      </td>
    </tr>
  )
}

const ConsumeRow = (props) => {
  return(
    <tr>
      <td className="cell-left">{__("Resource to consume")}</td>
      <td className="cell-right">
        <span><MaterialIcon materialId={1}/>{props.consume.fuel}</span>
        <span><MaterialIcon materialId={2}/>{props.consume.ammo}</span>
        <span><MaterialIcon materialId={3}/>{props.consume.steel}</span>
        <span><MaterialIcon materialId={4}/>{props.consume.bauxite}</span>
      </td>
    </tr>
  )
}

const MatRow = (props) => {
  let result = []
  let stage = ''

  switch (props.stage){
  case 0:
    stage = <span><FontAwesome name='star' /> 1 ~ <FontAwesome name='star' /> 6 </span>
    break
  case 1:
    stage = <span><FontAwesome name='star' /> 6 ~ <FontAwesome name='star' /> MAX </span>
    break
  case 2:
    stage = <span>{__("upgrade")}</span>
    break
  }

  if (props.item.icon){
    result.push(
      <SlotitemIcon
        slotitemId={props.item.icon}
      />
    )
    result.push(
      <i>{__r(props.item.name)} × {props.item.count}</i>
    )
  }

  return(
    <tr>
      <td className="cell-left">
        {stage}
      </td>
      <td className="cell-right">
        <span><MaterialIcon materialId={7}/>{props.development[0]}({props.development[1]})</span>
        <span><MaterialIcon materialId={8}/>{props.improvement[0]}({props.improvement[1]})</span>
        { result }
      </td>
    </tr>
  )
}


class ItemInfoArea extends Component{

  constructor(props){
    super(props)

    let day = (new Date).getUTCDay()
    if ((new Date).getUTCHours() >= 15){
      day = (day + 1) % 7
    }

    this.state ={
      day: day,
      highlights: config.get('plugin.ItemImprovement.highlights', []),
      rowsExpanded: {},
    }
  }


  getRows = () => {
    let day = this.state.day
    let rows = []

    for (let item of DATA){
      let hishos = []
      for (let improvement of item.improvement){
        for (let req of improvement.req){
          for (let secretary of req.secretary){
            if (req.day[day]){
              hishos.push (__(window.i18n.resources.__ (secretary)))
            }
          }
        }
      }
      let highlight = _.includes(this.state.highlights, item.id)
      if (hishos.length > 0){
        let row = {
          id: item.id,
          icon: item.icon,
          type: window.i18n.resources.__ (item.type),
          name: window.i18n.resources.__ (item.name),
          hisho: hishos.join(' / '),
          highlight: highlight,
        }
        rows.push(row)
      }
    }
    return rows
  }

  handleKeyChange = (key) => {
    this.setState({
      day: key,
      rowsExpanded: {},
    })
  }

  handleClickItem = (id) => {
    let highlights = _.clone(this.state.highlights)
    if (_.includes(highlights,id)) {
      highlights = highlights.filter((v) => v != id)
    }

    else {
      highlights.push(id)
    }
    config.set('plugin.ItemImprovement.highlights', highlights)

    this.setState({
      highlights: highlights,
    })
  }

  handleRowExpanded = (id, expanded) =>{
    let rowsExpanded = _.clone(this.state.rowsExpanded)
    rowsExpanded[id] = expanded
    this.setState({
      rowsExpanded: rowsExpanded,
    })
  }

  renderRows = () => {
    let rows = this.getRows()
    let highlighted = []
    let normal = []
    let result = []
    if (rows != null){
      for (let row of rows){

        let ref = row.highlight ? highlighted : normal

        let rowExpanded = this.state.rowsExpanded[row.id] || false
        ref.push (
          <ItemInfoRow
            key = {row.id}
            icon = {row.icon}
            type = {row.type}
            name = {row.name}
            hisho = {row.hisho}
            highlight = {row.highlight}
            clickCheckbox = {this.handleClickItem.bind(this, row.id)}
            rowExpanded = {rowExpanded}
            setExpanded = {this.handleRowExpanded.bind(this, row.id)}
          />
        )
        ref.push (
          <DetailRow
            key = {"detail-"+row.id}
            id = {row.id}
            icon = {row.icon}
            type = {row.type}
            name = {row.name}
            rowExpanded = {rowExpanded}
            day = {this.state.day}
          />
        )
      }
      result = _.concat(highlighted, normal)
    }

    return (result)
  }


  render(){
    return(
      <Grid id="item-info-area">
        <div id='item-info-settings'>
          <Divider text={__("Weekday setting")} />
          <Grid className='vertical-center'>
            <Col xs={12}>
              <Nav bsStyle="pills" activeKey={this.state.day} onSelect={this.handleKeyChange}>
                <NavItem eventKey={0}>{__ ("Sunday")}</NavItem>
                <NavItem eventKey={1}>{__ ("Monday")}</NavItem>
                <NavItem eventKey={2}>{__ ("Tuesday")}</NavItem>
                <NavItem eventKey={3}>{__ ("Wednesday")}</NavItem>
                <NavItem eventKey={4}>{__ ("Thursday")}</NavItem>
                <NavItem eventKey={5}>{__ ("Friday")}</NavItem>
                <NavItem eventKey={6}>{__ ("Saturday")}</NavItem>
              </Nav>
            </Col>
          </Grid>
          <Divider text={__ ("Improvement information")} />
          <Grid>
            <Table bordered condensed hover id="main-table">
            <thead className="item-table">
              <tr>
                <th width="200" ><div style={{paddingLeft: '55px'}}>{__ ("Type")}</div></th>
                <th width="250" >{__ ("Name")}</th>
                <th width="200" >{__ ("2nd Ship")}</th>
              </tr>
            </thead>
            <tbody>
            {this.renderRows()}
            </tbody>
            </Table>
          </Grid>
        </div>
      </Grid>
    )

  }
}


ReactDOM.render(<ItemInfoArea />, $('item-improvement'))
