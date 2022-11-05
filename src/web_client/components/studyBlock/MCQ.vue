<template>
    <BlockBuilderBlock>
        <div class="p-4">
            <h2>Question</h2>
            <div class="mt-4 w-full h-20 border border-gray-500 border-dashed rounded-lg"></div>
            <p>{{block.mcq_question_text}}</p>
        </div>
        <hr>

        <BlockBuilderMultipleChoice 
            :choices="block.mcq_answer_choices"
            :corrected="selectedResults"
            @select="(choiceKey) => selected = choiceKey"/>

        {{ selectedResults }}

        <BlockBuilderControlsSingle @click="test()">
            Check Answer & Continue
        </BlockBuilderControlsSingle>
    </BlockBuilderBlock>
</template>

<script setup>
 import { ref } from 'vue';
 import BlockBuilderBlock from '@/components/blockBuilder/Block.vue';
 const emit = defineEmits(['consume']);

 const props = defineProps(['block']);
 const block = ref(props.block);

 //gets assigned the key of whatever is selected at the moment.
 let selected = ref("");
 let selectedResults = ref({});

 const { testBlock, testResult } = useStudyBlockHelpers(block, emit);

 function test() {
     testBlock(selected.value);
     selectedResults.value[selected.value] = testResult;
 }
</script>
