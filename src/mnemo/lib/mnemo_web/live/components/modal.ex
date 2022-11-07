defmodule MnemoWeb.Live.Components.Modal do
  use Phoenix.Component

  attr :button_text, :string, required: true
  attr :button_class, :string, default: nil
  slot(:icon)
  slot(:button_left)
  slot(:button_right)
  slot(:inner_block)

  def confirmation(assigns) do
    ~H"""
        <div x-data="{ modalOpen: false }">
            <button
                x-on:click="modalOpen = !modalOpen"
                class={ @button_class || "px-4 py-2 text-sm border border-red-600 rounded-lg" }>
                <%= @button_text %>
            </button>

            <div x-show="modalOpen" class="relative z-10" aria-labelledby="modal-title" role="dialog" aria-modal="true">
                <!--
                    Background backdrop, show/hide based on modal state.

                    Entering: "ease-out duration-300"
                    From: "opacity-0"
                    To: "opacity-100"
                    Leaving: "ease-in duration-200"
                    From: "opacity-100"
                    To: "opacity-0"
                -->
                <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>

                <div class="fixed inset-0 z-10 overflow-y-auto">
                    <div class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
                        <!--
                            Modal panel, show/hide based on modal state.

                            Entering: "ease-out duration-300"
                            From: "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                            To: "opacity-100 translate-y-0 sm:scale-100"
                            Leaving: "ease-in duration-200"
                            From: "opacity-100 translate-y-0 sm:scale-100"
                            To: "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
                        -->
                        <div class="relative transform overflow-hidden rounded-lg bg-white text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg">
                            <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                                <div class="sm:flex sm:items-start">
                                    <div class="mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10">
                                        <%= render_slot(@icon) %>
                                    </div>
                                    <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                                        <h3 class="text-lg font-medium leading-6 text-gray-900" id="modal-title">Deactivate account</h3>
                                        <div class="mt-2">
                                            <p class="text-sm text-gray-500">
                                                <%= render_slot(@inner_block) %>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="bg-gray-50 px-4 py-3 sm:flex sm:flex-row-reverse sm:px-6">
                                <%= render_slot(@button_left) %>
                                <%= render_slot(@button_right) %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    """
  end
end
