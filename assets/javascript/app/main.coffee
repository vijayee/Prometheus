require
  shim:
    jquery:
      exports:'$'
    semantic:
      deps:['jquery']
  paths:
    jquery: '../vendor/jquery/jquery-2.1.1.min'
    angular:'../vendor/angular/angular.min'
    semantic:'../vendor/semantic/semantic.min'
  ['jquery', 'angular','semantic']
  ($, Angular,Semantic)->
    console.log(Angular)
    $('.ui.dropdown').dropdown()
