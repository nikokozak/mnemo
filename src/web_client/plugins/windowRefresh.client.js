export default defineNuxtPlugin(vueApp => {
    window.onpopstate = function() {
        location.reload();
    }
})
