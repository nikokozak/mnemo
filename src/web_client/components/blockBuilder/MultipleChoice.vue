<template>
    <template v-for="(choice, index) in choices" :key="index">
        <div @click="select(choice)" 
            :class="{'border-blue-400': selected == choice.key, 
            'border-red-400': corrected[choice.key] == false }"
            class="flex justify-between border rounded-lg text-xs mt-4 mr-4">
            <div class="w-8 pl-3 border-r">
                <p class="pr-2 pt-2">{{ choice.key }}</p>
            </div>
            <p class="px-4 py-2">{{ choice.text }}</p>
        </div>
        {{ corrected  }}
    </template>
</template>

<script setup>
    import { unref } from 'vue';
    const props = defineProps(['choices', 'selected', 'corrected']);
    const emit = defineEmits(['select']);

    const choices = ref(props.choices);
    const selected = ref(props.selected);

    function select(choice) {
        selected.value = choice.key;
        emit('select', choice.key);
    }
</script>
