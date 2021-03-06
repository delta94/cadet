defmodule CadetWeb.AnswerController do
  use CadetWeb, :controller

  use PhoenixSwagger

  alias Cadet.Assessments

  def submit(conn, %{"questionid" => question_id, "answer" => answer})
      when is_ecto_id(question_id) do
    case Assessments.answer_question(question_id, conn.assigns.current_user, answer) do
      {:ok, _nil} ->
        text(conn, "OK")

      {:error, {status, message}} ->
        conn
        |> put_status(status)
        |> text(message)
    end
  end

  def submit(conn, _parms) do
    send_resp(conn, :bad_request, "Missing or invalid parameter(s)")
  end

  swagger_path :submit do
    post("/assessments/question/{questionId}/submit")

    summary("Submit an answer to a question.")

    description(
      "For MCQ, answer contains choice_id. For programming question, this is a string containing the student's code."
    )

    security([%{JWT: []}])

    consumes("application/json")

    parameters do
      questionId(:path, :integer, "question id", required: true)
      answer(:body, Schema.ref(:Answer), "answer", required: true)
    end

    response(200, "OK")
    response(400, "Invalid parameters")
    response(403, "User not permitted to answer questions or assessment not open")
    response(404, "Assessment not found")
  end

  def swagger_definitions do
    %{
      Answer:
        swagger_schema do
          properties do
            answer(
              :string_or_int,
              "answer of appropriate type depending on question type",
              required: true
            )
          end
        end
    }
  end
end
