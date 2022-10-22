<template>
    <BlockBuilderBlock>
        <div class="p-4">
            <h2>Front</h2>
            <BlockBuilderTextAndImage :bricks="block.fc_front_content" />
        </div>

        <template v-if="showBack">
            <div class="p-4">
                <h2>Back</h2>

                <BlockBuilderTextAndImage :bricks="block.fc_back_content" />
            </div>
        </template>

        <template #controls>
            <BlockBuilderControlsSingle v-if="!showBack" @click="showBack = true">
                <template #icon><IconDownArrows class="w-4 h-4 mr-2"/></template>
                Reveal Back of Card
            </BlockBuilderControlsSingle>
            <BlockBuilderControlsSingle v-else @click="testBlock">
                <template #icon><IconDownArrows class="w-4 h-4 mr-2"/></template>
                Continue
            </BlockBuilderControlsSingle>
        </template>
    </BlockBuilderBlock>
</template>

<script setup>
import { ref } from 'vue';
import BlockBuilderBlock from '@/components/blockBuilder/Block.vue';

const emit = defineEmits(['consume']);

const props = defineProps(['block']);
const block = ref(props.block);

const showBack = ref(false);

const { testBlock } = useStudyBlockHelpers(block, emit);
</script>
