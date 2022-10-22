<template>
    <div class="flex text-xs border-t mt-4 py-2 justify-center"> 
        <div @click="emit('click')" class="flex">
            <slot name="icon"></slot>
            <slot>{{props.text}}</slot>
        </div>
    </div>
</template>

<script setup>
const props = defineProps(['text']);
const emit = defineEmits(['click']);
</script>
