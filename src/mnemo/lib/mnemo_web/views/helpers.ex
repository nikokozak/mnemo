defmodule MnemoWeb.ViewHelpers do
  def filter_block_fields_by_type(block) do
    base_block =
      Map.take(block, [:id, :type, :testable, :order_in_section, :section_id, :subject_id, :media])

    filtered_block =
      case block.type do
        "static" ->
          Map.take(block, [:static_content])

        "saq" ->
          Map.take(block, [:saq_question_img, :saq_question_text, :saq_answer_choices])

        "mcq" ->
          Map.take(block, [
            :mcq_question_img,
            :mcq_question_text,
            :mcq_answer_choices,
            :mcq_answer_correct
          ])

        "fibq" ->
          Map.take(block, [
            :fibq_question_img,
            :fibq_question_text,
            :fibq_question_answers,
            :fibq_question_text_template
          ])

        "fc" ->
          Map.take(block, [:fc_front_content, :fc_back_content])
      end

    Map.merge(base_block, filtered_block)
  end
end
