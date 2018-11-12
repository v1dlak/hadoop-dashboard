Batman.Filters.dateCalendar = (date) ->
  return 'Unknown' unless date
  moment(date * 1000).calendar()

Batman.Filters.dateFromNow = (date) ->
  return 'Unknown' unless date
  moment(date * 1000).fromNow()

class Dashing.FailedJobs extends Dashing.Widget

  ready: ->
    @currentIndex = 0
    @step = 5
    @jobsContainer = $(@node).find('.jobs-container')
    @rotate()
    setInterval(@rotate, 10 * 1000)

  onData: (data) ->
    @currentIndex = 0

  rotate: =>
    jobs = @get 'jobs'
    if jobs
      return @set 'current_jobs', jobs if @currentIndex is 0 and @step >= jobs.length
      @jobsContainer.fadeOut =>
        @set 'current_jobs', jobs[@currentIndex...@currentIndex + @step]
        if (@currentIndex + @step) > jobs.length
          @currentIndex = 0
        else
          @currentIndex = (@currentIndex + @step) % jobs.length
        @jobsContainer.fadeIn()
