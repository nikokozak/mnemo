<template>
    <div class="flex justify-between text-xs border-t mt-4"> 
        <div @click="emit('leftClick')" class="border-r w-1/2 flex pl-6 py-2">
            <slot name="leftIcon"></slot>
            <slot name="leftText">{{props.leftText}}</slot>
        </div>
        <div @click="emit('rightClick')" class="w-1/2 flex pl-6 py-2">
            <slot name="rightIcon"></slot>
            <slot name="rightText">{{props.rightText}}</slot>
        </div>
    </div>
</template>

<script setup>
const props = defineProps(['leftText', 'rightText']);
const emit = defineEmits(['leftClick', 'rightClick']);
</script>
