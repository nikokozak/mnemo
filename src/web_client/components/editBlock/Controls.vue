<template>
<BlockBuilderControlsDouble 
    leftText="Delete Block" 
    rightText="Save Block"
    @leftClick="emit('leftClick')"
    @rightClick="emit('rightClick')"
    >
    <template #leftIcon>
        <IconTrashDark class="w-4 h-4 mr-2" />
    </template>
    <template #rightIcon>
        <IconSave class="w-4 h-4 mr-2" />
    </template>
</BlockBuilderControlsDouble>
</template>

<script setup>
const props = defineProps(['leftText', 'rightText']);
const emit = defineEmits(['leftClick', 'rightClick']);
</script>
