require_relative '../exceptions'

class CogCmd::Cfn::Stack::Delete < Cog::SubCommand

  USAGE = <<-END.gsub(/^ {2}/, '')
  Usage: cfn:stack delete <stack name>

  Deletes a stack. Returns a map with the stack name and status.

  Note: This command returns the same regardless of success or failure. Use the cfn:event command to view the results of the delete.
  END

  def run
    unless request.args[0]
      raise CogCmd::Cfn::ArgumentError, "You must specify a stack name."
    end

    cloudform = Aws::CloudFormation::Client.new()
    cloudform.delete_stack(stack_name: request.args[0])

    { status: "delete initiated",
      stack_name: request.args[0] }
  end
end
