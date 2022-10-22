<template>
    <button @click="emit('click')" class="flex text-xs border rounded-lg py-2 px-4">
        <slot name="icon"></slot>
        <slot>Text Here</slot>
    </button>
</template>

<script setup>
const emit = defineEmits(['click']); 
</script>
