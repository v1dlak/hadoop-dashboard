class Dashing.Szn_employee extends Dashing.Widget

  ready: ->
    @currentIndex = 0
    @step = 7
    @employeeContainer = $(@node).find('.employee-container')
    @rotate()
    setInterval(@rotate, 10 * 1000)
    setInterval(@hol, 500)

  onData: (data) ->
    @currentIndex = 0

  rotate: =>
    employee = @get 'szn_employee'
    if employee
      return @set 'current_employee', employee if @currentIndex is 0 and @step >= employee.length
      @employeeContainer.fadeOut =>
        @set 'current_employee', employee[@currentIndex...@currentIndex + @step]
        
        if (@currentIndex + @step) > employee.length
          @currentIndex = 0
        else
          @currentIndex = (@currentIndex + @step) % employee.length
        
        @employeeContainer.fadeIn()

  hol: =>
    $('.failed', @node).each ->
      $el = $(this)
      #console.log($el.find('.status:first').html().substring(2, 4))
      if $el.find('.status:first').html().slice(0, 3) == 'dov'
        $el.css('background-color', '#e64d4d')
        $el.css('border-bottom', '5px solid #662d2d')
      if $el.find('.status:first').html().substring(2, 4) == 'hr'
        $el.css('background-color', '#e64d4d')
        $el.css('border-bottom', '5px solid #662d2d')
      if $el.find('.status:first').html().slice(0, 2) == 'Ob'
        $el.css('background-color', '#ff9933')
        $el.css('border-bottom', '5px solid #cc6600')
      if $el.find('.status:first').html().slice(0, 2) == 'Od'
        $el.css('background-color', '#ff9933')
        $el.css('border-bottom', '5px solid #cc6600')
      if $el.find('.name:first').html().slice(-4) == '[HO]'
        $el.css('background-color', '#3385ff')
        $el.css('border-bottom', '5px solid #0047b3')
        
