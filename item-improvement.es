require('coffee-react/register')


// env.coffee
const path = require('path-extra')
let ref

// Shortcuts and Components
window._ = require('lodash')
window.$ = (param) => document.querySelector(param)
window.$$ = (param) => document.querySelectorAll(param)
window.React = require('react')
window.ReactDOM = require('react-dom')
window.ReactBootstrap = require('react-bootstrap')
window.FontAwesome = require('react-fontawesome')

 // Node modules
window.config = remote.require('./lib/config')

 // language setting
window.language = config.get('poi.language', navigator.language)

 // Custom theme
window.theme = config.get('poi.theme', '__default__')
window.isDarkTheme = /(dark|black|slate|superhero|papercyan)/i.test(theme)
if(theme == '__default__'){
  if($('#bootstrap-css')){
    $('#bootstrap-css').setAttribute('href', "file://" + require.resolve('bootstrap/dist/css/bootstrap.css'))
  }
}
else{
  if($('#bootstrap-css')){
    $('#bootstrap-css').setAttribute('href', `file://${ROOT}/assets/themes/${theme}/css/${theme}.css`)
  }
}

window.addEventListener('theme.change', (e) => {
  window.theme = e.detail.theme
  if(theme == '__default__'){
    if($('#bootstrap-css')){
      $('#bootstrap-css').setAttribute('href', "file://" + require.resolve('bootstrap/dist/css/bootstrap.css'))
    }
  }
  else{
    if($('#bootstrap-css')){
      $('#bootstrap-css').setAttribute('href', `file://${ROOT}/assets/themes/${theme}/css/${theme}.css`)
    }
  }
})


// User setting
window.useSVGIcon = config.get('poi.useSVGIcon', false)

// i18n
import {join} from 'path-extra'

import i18n2 from 'i18n-2'

const i18n = new i18n2({
  locales: ['en-US', 'ja-JP', 'zh-CN', 'zh-TW'],
  defaultLocale: 'zh-CN',
  directory: join(__dirname, 'i18n'),
  extension: '.json',
  updateFiles: false,
  devMode: false,
})
i18n.setLocale(window.language)

window.__ = i18n.__.bind(i18n)

if(i18n.resources == null){
  i18n.resources = {}
}

try{
  require('poi-plugin-translator').pluginDidLoad()
}
catch(error){
  console.log(error)
}

if(i18n.resources.__ == null){
  i18n.resources.__ = (str) => str
}
if(i18n.resources.translate == null){
  i18n.resources.translate = (locale, str) => str
}
if(i18n.resources.setLocale == null){
  i18n.resources.setLocale = (str) => {}
}

window.__r = i18n.resources.__.bind(i18n.resources)

window.i18n = i18n

document.title = __('Equipment Improvement')


require('./views')
