<template>
    <div>
        <template v-if="!pending">
            <SubjectInformation :subject="subject" />
            <SubjectContent :subject="subject" />
            <SubjectOptions :subject="subject" /> 
        </template>
    </div>
</template>

<script setup>
    const route = useRoute();

    const subjectId = route.params.subjectId;
    const student = "nikokozak@gmail.com";

    const { data: subject, pending } = await useFetchAPI(`/api/subjects/${subjectId}`, {key: subjectId});
</script>
