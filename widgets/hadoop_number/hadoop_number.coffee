class Dashing.HadoopNumber extends Dashing.Widget
  @accessor 'current_live', Dashing.AnimatedValue

  @accessor 'difference_live', ->
    if @get('last_live')
      last_live = parseInt(@get('last_live'))
      current_live = parseInt(@get('current_live'))
      if last_live != 0
        diff = Math.abs(Math.round((current_live - last_live) / last_live * 100))
        "#{diff}%"
    else
      ""

  @accessor 'arrow_live', ->
    if @get('last_live')
      if parseInt(@get('current_live')) == parseInt(@get('last_live')) then 'icon-arrow-right' else if parseInt(@get('current_live')) > parseInt(@get('last_live')) then 'icon-arrow-up' else 'icon-arrow-down'



  @accessor 'current_dead', Dashing.AnimatedValue

  @accessor 'difference_dead', ->
    if @get('last_dead')
      last_dead = parseInt(@get('last_dead'))
      current_dead = parseInt(@get('current_dead'))
      if last_dead != 0
        diff = Math.abs(Math.round((current_dead - last_dead) / last_dead * 100))
        "#{diff}%"
    else
      ""

  @accessor 'arrow_dead', ->
    if @get('last_dead')
      if parseInt(@get('current_dead')) == parseInt(@get('last_dead')) then 'icon-arrow-right' else if parseInt(@get('current_dead')) > parseInt(@get('last_dead')) then 'icon-arrow-up' else 'icon-arrow-down'


  @accessor 'current_deco', Dashing.AnimatedValue

  @accessor 'difference_deco', ->
    if @get('last_deco')
      last_deco = parseInt(@get('last_deco'))
      current_deco = parseInt(@get('current_deco'))
      if last_deco != 0
        diff = Math.abs(Math.round((current_deco - last_deco) / last_deco * 100))
    else
      ""

  @accessor 'arrow_deco', ->
    if @get('last_deco')
      if parseInt(@get('current_deco')) == parseInt(@get('last_deco')) then 'icon-arrow-right' else if parseInt(@get('current_deco')) > parseInt(@get('last_deco')) then 'icon-arrow-up' else 'icon-arrow-down'



  onData: (data) ->
    if data.status
      # clear existing "status-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''
      # add new class
      $(@get('node')).addClass "status-#{data.status}"
