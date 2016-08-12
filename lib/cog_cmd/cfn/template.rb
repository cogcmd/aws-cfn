class CogCmd::Cfn::Template < Cog::Command
  def run_command
    case request.args[0]
    when "list"
      list
    when "describe"
      describe
    else
      usage
    end
  end

  private

  def usage
    response["body"] = "Usage: cfn:template < list | describe <name> >"
  end

  def list
    response.content = {
      "templates": [
        {
          "name": "template1",
          "last_modified": "2016-08-12 00:00:00"
        }
      ]
    }
  end

  def describe
    response.content = {
      "parameters": []
    }
  end
end
