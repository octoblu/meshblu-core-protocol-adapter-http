JobManager = require 'meshblu-core-job-manager'
MeshbluAuthParser = require '../helpers/meshblu-auth-parser'
debug = require('debug')('meshblu-server-http:subscription-controller')

class SubscriptionsController
  constructor: ({@timeoutSeconds}) ->
    @authParser = new MeshbluAuthParser

  list: (req, res) =>
    jobManager = new JobManager
      client: req.connection
      timeoutSeconds: @timeoutSeconds

    auth = @authParser.parse req

    options =
      metadata:
        auth: auth
        fromUuid: req.get('x-as') ? auth.uuid
        toUuid: req.params.uuid
        jobType: 'SubscriptionList'

    jobManager.do 'request', 'response', options, (error, response) =>
      return res.status(error.code ? 500).send(error.message) if error?
      res.status(response.metadata.code).send JSON.parse(response.rawData)

module.exports = SubscriptionsController
