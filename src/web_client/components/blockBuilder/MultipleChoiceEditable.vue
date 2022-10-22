<template>
    <template v-for="(choice, index) in choices" :key="index">
        <div class="flex justify-between border rounded-lg text-xs mt-4 mr-4">
            <div class="w-8 pl-3 border-r">
                <p class="pr-2 pt-2">{{ choice.key }}</p>
            </div>
            <textarea v-model="choice.text" class="pl-2 pt-2">
            </textarea>
            <!-- answer picker for first two choices -->
            <template v-if="index < 2">
                <div class="pl-2 border-l justify-self-end w-8 pt-2">
                    <IconCheckMarkDark v-if="correctAnswer == choice.key" class="w-4 h-4" />
                    <IconCheckMark v-else @click="selectChoice(choice)" class="w-4 h-4" />
                </div>
            </template>
            <!-- answer picker for other choices -->
            <template v-else>
                <div class="border-l justify-self-end w-8">
                    <div class="pl-2 py-2">
                        <IconCheckMarkDark v-if="correctAnswer == choice.key" class="w-4 h-4" />
                        <IconCheckMark v-else @click="selectChoice(choice)" class="w-4 h-4" />
                    </div>
                    <hr>
                    <div class="pl-2">
                        <IconTrash @click="removeChoice(choice)" class="my-2 mr-0 w-4 h-4" />
                    </div>
                </div>
            </template>
        </div>
    </template>

    <div class="flex justify-around mt-4">
        <MiscButton @click="addChoice">
            <template #icon><IconText class="w-4 h-4 mr-2" /></template>
            Add another answer
        </MiscButton>
    </div>
</template>

<script setup>
    import { unref } from 'vue';
    const props = defineProps(['choices', 'correctAnswer']);
    const emit = defineEmits(['select', 'remove', 'add']);

    const choices = ref(props.choices);
    const correctAnswer = ref(props.correctAnswer);
    const returnValue = computed(() => {
        return {
            choices: unref(choices),
            correctAnswer: unref(correctAnswer)
        }
    })

function selectChoice(choice) {
    correctAnswer.value = choice.key;
    emit('select', returnValue.value);
}

function addChoice() {
    choices.value.push({
        key: getNextKey(),
        text: "Another answer"
    });
    emit('add', returnValue.value);
}

function removeChoice(choice) {
    const idx = choices.value.indexOf(choice, 1);
    choices.value.splice(idx, 1);
    resetAnswerKeys();
    emit('remove', returnValue.value);
}

function getNextKey() {
    const ac = props.choices;
    const last_key = ac[ac.length - 1].key;
    return String.fromCharCode(last_key.charCodeAt(0) + 1);
}


function resetAnswerKeys() {
    choices.value.forEach((choice, idx) => {
        choice.key = String.fromCharCode(idx + 97); 
    });

    const correctCharCode = correctAnswer.value.charCodeAt(0);
    const maxCharCode = choices.value.length + 96;
    if (correctCharCode > maxCharCode) {
        correctAnswer.value = String.fromCharCode(maxCharCode);
    }
}

</script>
