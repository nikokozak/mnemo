<template>
    <div class="border rounded-lg mt-2 mb-4">
        <template v-if="title">
            <div class="flex m-4 text-md">
                <slot name="icon"></slot>
                <h1>{{ title }}</h1>
            </div>
            <hr>
        </template>

        <slot>Rest of the block</slot>

        <slot name="controls"></slot>
    </div>
</template>

<script setup>
const props = defineProps(['title']);
const title = props.title;

</script>
