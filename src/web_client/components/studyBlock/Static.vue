<template>
    <BlockBuilderBlock>
        <BlockBuilderTextAndImage
            :bricks="block.static_content" />

        <BlockBuilderControlsSingle @click="testBlock">
            Continue
        </BlockBuilderControlsSingle>
    </BlockBuilderBlock>
</template>

<script setup>
import { ref } from 'vue';
import BlockBuilderBlock from '@/components/blockBuilder/Block.vue';

const emit = defineEmits(['consume']);

const props = defineProps(['block']);
const block = ref(props.block);

const { testBlock } = useStudyBlockHelpers(block, emit);
</script>
