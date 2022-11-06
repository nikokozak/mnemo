defmodule MnemoWeb.Live.Subject.Components.Modals do
  use Phoenix.Component
  import Phoenix.HTML.Form, only: [submit: 2]
  alias MnemoWeb.Router.Helpers, as: Routes
  alias MnemoWeb.Live.Components.Modal

  attr :socket, :map, required: true
  attr :subject, :map, required: true

  def deletion(assigns) do
    ~H"""
        <Modal.confirmation button_text="Delete Subject" >

            <:icon>
                <!-- Heroicon name: outline/exclamation-triangle -->
                <svg class="h-6 w-6 text-red-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 10.5v3.75m-9.303 3.376C1.83 19.126 2.914 21 4.645 21h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 4.88c-.866-1.501-3.032-1.501-3.898 0L2.697 17.626zM12 17.25h.007v.008H12v-.008z" />
                </svg>
            </:icon>

            Are you sure you want to delete this subject?

            <:button_left>
                <.form for={:subject_deletion} action={Routes.subject_path(@socket, :delete, subject_id: @subject.id)}>
                    <%= submit "Delete Subject",
                    class: "inline-flex w-full justify-center rounded-md border border-transparent bg-red-600 px-4 py-2 text-base font-medium text-white shadow-sm hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 sm:ml-3 sm:w-auto sm:text-sm",
                    "x-on:click": "modalOpen = !modalOpen"
                    %>
                </.form>
            </:button_left>

            <:button_right>
                <button x-on:click="modalOpen = !modalOpen" type="button" class="mt-3 inline-flex w-full justify-center rounded-md border border-gray-300 bg-white px-4 py-2 text-base font-medium text-gray-700 shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm">Cancel</button>
            </:button_right>


        </Modal.confirmation>

    """
  end
end
