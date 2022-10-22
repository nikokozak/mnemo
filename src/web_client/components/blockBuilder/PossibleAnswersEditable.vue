<template>
    <div class="p-4">
        <h2>Possible Answers</h2>

        <template v-for="(choice, index) in choices" :key="index">
            <div class="flex justify-between border rounded-lg text-xs mt-4 mr-4">
                <input v-model="choice.text" placeholder="An answer here" class="pl-2 py-2 w-full rounded-lg" />

                <div v-if="index > 0" class="pl-2 border-l justify-self-end w-8">
                    <IconTrash @click="removeAnswerChoice(choice)" class="my-2 mr-0 w-4 h-4" />
                </div>
            </div>
        </template>

        <div class="flex justify-around mt-4">
            <MiscButton @click="addAnswerChoice">
                <template #icon><IconText class="w-4 h-4 mr-2" /></template>
                Add another possible answer
            </MiscButton>
        </div>
    </div>
</template>

<script setup>
import { ref, unref } from 'vue';

const emit = defineEmits(['add', 'remove']);
const props = defineProps(['choices', 'editable']);
const choices = ref(props.choices);

function addAnswerChoice() {
    choices.value.push(newAnswer());
    emit('add', unref(choices));
}

function removeAnswerChoice(choice) {
    const choiceIdx = choices.value.indexOf(choice, 1);
    choices.value.splice(choiceIdx, 1);
    emit('remove', unref(choices));
}

function newAnswer() {
    return { text: "" }
}
</script>
