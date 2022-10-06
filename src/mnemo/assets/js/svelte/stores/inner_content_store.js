import { writable } from 'svelte/store';


const mcQuestions = () => {
    return {
    
    answer: {
        choices: {
            "a": "A first answer here",
            "b": "A second answer here"
        },
        correct: "b"
    },
    question: {
        image: "",
        text: "A question related to multiple choice answers below."
    }
    }
}

export function createInnerContentStore() {
    const { subscribe, set, update } = writable(mcQuestions());

    return {
        subscribe,
        writable,
        set,
        update
    }
}
