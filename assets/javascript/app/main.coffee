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
    calculatorApp= angular.module('calculatorApp',[])
    calculatorApp.controller 'CalculatorController',['$scope','$http',($scope,$http) ->
      $scope.operations=[]
      $scope.result= "0"
      requestCalculation=->
        if $scope.operations.length == 0
          return
        data=generateExpression()
        openParan = (data.calculation.match(/\(/g) || []).length
        closeParan = (data.calculation.match(/\)/g) || []).length
        if openParan != closeParan
          return
          scope=$scope
        $http.post('/calculator', data).success (data, status, headers, config) ->
          $scope.result= data.Result
        .error (data, status, headers, config) ->
          $scope.result= data
      generateExpression=->
        expression=""
        for operand in $scope.operations
          expression= expression.concat(operand)
        {calculation:expression}
      $scope.expression=generateExpression
      accumulateNumber=(num)->
        num=String(num)
        last=$scope.operations.pop()
        if last?
          if $.isNumeric(last) or last=="."
            if num=="." and String(last).indexOf(".") != -1
              $scope.operations.push(last)
              return
            last=String(last).concat(num)
            $scope.operations.push(last)
            $scope.result=last
          else
            if last != ")" and last != ",2)" and last != ",.5)"
              $scope.operations.push(last)
              $scope.operations.push(num)
              $scope.result=num
            else
              $scope.operations.push(last)
        else
          $scope.operations.push(num)
          $scope.result=num
      accumulateOperator=(operand)->
        if $scope.operations.length == 0
          return
        last=$scope.operations.pop()
        if last?
          if $.isNumeric(last)
            $scope.operations.push(last)
            requestCalculation()
            $scope.operations.push(operand)
          else
            $scope.operations.push(last)
            $scope.operations.push(operand) if last == ")" or  last == ",2)"  or last == ",.5)"
      negateOperations=->
        if $scope.operations.length == 0
          return

        last=$scope.operations.pop()
        if $.isNumeric(last)
          if last== $scope.result
            $scope.operations.push("-(")
            $scope.operations.push(last)
            $scope.operations.push(")")
          else
            $scope.operations.push(last)
            $scope.operations.unshift("-(")
            $scope.operations.push(")")
        else
          if last==")" or last==",2)" or last==",.5)"
            $scope.operations.push(last)
            data=generateExpression()
            openParen = (data.calculation.match(/\(/g) || []).length
            closeParen = (data.calculation.match(/\)/g) || []).length
            if openParen == closeParen
              $scope.operations.unshift("-(")
              $scope.operations.push(")")
        requestCalculation()
      squareOperations=->
        if $scope.operations.length == 0
          return
        last=$scope.operations.pop()
        if $.isNumeric(last)
          if last== $scope.result
            $scope.operations.push("Math.pow(")
            $scope.operations.push(last)
            $scope.operations.push(",2)")
          else
            $scope.operations.push(last)
            $scope.operations.unshift("Math.pow(")
            $scope.operations.push(",2)")
        else
          if last==")" or last==",2)" or last==",.5)"
            $scope.operations.push(last)
            data=generateExpression()
            openParen = (data.calculation.match(/\(/g) || []).length
            closeParen = (data.calculation.match(/\)/g) || []).length
            if openParen == closeParen
              $scope.operations.unshift("Math.pow(")
              $scope.operations.push(",2)")
        requestCalculation()
      squareRootOperations=->
        if $scope.operations.length == 0
          return
        last=$scope.operations.pop()
        if $.isNumeric(last)
          if last== $scope.result
            $scope.operations.push("Math.pow(")
            $scope.operations.push(last)
            $scope.operations.push(",.5)")
          else
            $scope.operations.push(last)
            $scope.operations.unshift("Math.pow(")
            $scope.operations.push(",.5)")
        else
          if last==")" or last==",2)" or last==",.5)"
            $scope.operations.push(last)
            data=generateExpression()
            openParen = (data.calculation.match(/\(/g) || []).length
            closeParen = (data.calculation.match(/\)/g) || []).length
            if openParen == closeParen
              $scope.operations.unshift("Math.pow(")
              $scope.operations.push(",.5)")
        requestCalculation()
      clear=->
        $scope.operations=[]
        $scope.result= "0"
      parenthesize= (operator)->
        if operator == "("
          last=$scope.operations.pop()
          if last?
            if $.isNumeric(last)
              $scope.operations.push(last)
              return
            else
              $scope.operations.push(last)
              $scope.operations.push(operator) if last != ")"
          else
            $scope.operations.push(operator)
        else
          last=$scope.operations.pop()
          if not last?
            return
          if $.isNumeric(last) or last==")"
            $scope.operations.push(last)
            data=generateExpression()
            openParan = (data.calculation.match(/\(/g) || []).length
            closeParan = (data.calculation.match(/\)/g) || []).length
            if openParan > closeParan
              $scope.operations.push(operator)
              requestCalculation()
          else
            $scope.operations.push(last)

      $scope.operate= (operator)->
        if $.isNumeric(operator) and operator != '-1'
          accumulateNumber(operator)
        else
          switch operator
            when "." then accumulateNumber(operator)
            when "+" then accumulateOperator(operator)
            when "-" then accumulateOperator(operator)
            when "*" then accumulateOperator(operator)
            when "/" then accumulateOperator(operator)
            when "-1" then negateOperations()
            when "=" then requestCalculation()
            when "clear" then clear()
            when "(" then parenthesize(operator)
            when ")" then parenthesize(operator)
            when "^2" then squareOperations()
            when "^1/2" then squareRootOperations()
    ]
    angular.element(document).ready ->
      angular.bootstrap(document, ['calculatorApp'])
