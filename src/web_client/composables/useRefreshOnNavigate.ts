// Will force a refresh on "back".
export default function() {
    window.onpopstate = function() {
        location.reload();
    }
}
