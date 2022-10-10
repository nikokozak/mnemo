<template>
    <div>
        <SubjectInformation :subjectId="subjectId" />
        <SubjectContent :subjectId="subjectId" />
        <SubjectOptions :subjectId="subjectId" /> 
    </div>
</template>

<script setup>
    const route = useRoute();

    const subjectId = route.params.subjectId;
    const student = "nikokozak@gmail.com";
</script>
